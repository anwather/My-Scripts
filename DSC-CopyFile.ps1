Configuration CopyFile
    {

    Import-DSCResource -ModuleName xRoboCopy,PSDesiredStateConfiguration

    Node localhost
        {

        xRoboCopy CopyFiles
            {
                Source="C:\Temp\Folder1"
                Destination="C:\Temp\Folder2"
                AdditionalArgs = "/MIR"
            }

        }
    }

