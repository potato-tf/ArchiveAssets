local steamid = NetProps.GetPropString(self, "m_szNetworkIDString")
local filename = "unlockedmirrormode"
local unlocked = false
local i = 1

//initialize first file
if (FileToString(filename+i) == null) StringToFile(filename+i, steamid)

// search every file for steamid
do {
    if (FileToString(filename+(i)).find(steamid) != null) unlocked = true
    i++
} while (FileToString(filename+(i)) != null)

if (unlocked == false) //if steamid is not found, write steamid to the latest file
{
    i--
    if ((FileToString(filename+i)+steamid).len() <= 16384) //if the latest file will contain more than 16384 characters, write to new file
    {
        StringToFile(filename+i, FileToString(filename+i)+steamid)
    }
    else 
    {
        i++
        StringToFile(filename+i, steamid)
    }
}