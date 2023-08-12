function Component()
{
    // default constructor
}

Component.prototype.createOperations = function()
{
    // call default implementation to actually install README.txt!
    component.createOperations();

    if (systemInfo.productType === "windows") {
        component.addOperation("CreateShortcut", "@TargetDir@/Clinup.exe", "@StartMenuDir@/Clinup.lnk",
            "workingDirectory=@TargetDir@", "iconPath=",
            "iconId=", "description=Open Clinup");
    }
}