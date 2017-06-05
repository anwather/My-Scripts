. .\Get-MyService.ps1
Describe "Get-MyService.ps1" {
    Context "Input" {
        It "ServiceName should be mandatory" {
            $cmd = Get-ChildItem Function:\Get-MyService
            $cmd.Parameters.ServiceName.Attributes.mandatory | Should Be True
        }
        It "Should process items in a pipeline" {
            Mock -Command Get-Service -MockWith {return @{Status="Running"}} 
            $svc = "Service1","Service2"
            $svc | Get-MyService
            Assert-MockCalled -CommandName Get-Service -Times 2
        }
    }

    Context "Process" {
        It "Should throw if service is not found"  {
            {Get-MyService -ServiceName fakeservice} | Should Throw
        }
        It "Should return multiple values from a pipeline" {
             Mock -Command Get-Service -MockWith {return @{Status="Running"}} 
             $svc = "Service1","Service2"
             $obj = $svc | Get-MyService
             $obj.Count | Should BeExactly 2
        } 
    }

    Context "Output" {
        It "Should return running if service is running" {
            Mock -Command Get-Service -MockWith {return @{Status="Running"}}
            Get-MyService -ServiceName Running | Should Be "Running"
        }
        It "Should return stopped if service is stopped" {
            Mock -Command Get-Service -MockWith {return @{Status="Stopped"}}
            Get-MyService -ServiceName Running | Should Be "Stopped"
        }
    }

}