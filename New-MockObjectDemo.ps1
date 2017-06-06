Describe "Mock-Object Tests" {

    It "Creates a new mock object" {
        mock 'Get-ChildItem' { 
            
            $obj = New-MockObject -Type 'System.IO.FileInfo' -Verbose -Debug
           Grandma
        }

        Get-ChildItem c:\Windows
        Assert-MockCalled -CommandName Get-ChildItem -Times 1
    }
}
