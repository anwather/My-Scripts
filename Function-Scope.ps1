function ParentFunction
    {
    function ChildFunction
        {
        "This is the child function"
        #$x = 10
        #"Value of `$x is $x"
        }
    "This is the parent function"
    ChildFunction
    #"Value of `$x is $x"
    }