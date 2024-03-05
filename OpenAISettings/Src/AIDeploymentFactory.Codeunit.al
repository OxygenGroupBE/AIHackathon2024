codeunit 56162 "AI Deployment Factory"
{
    SingleInstance = true;


    var
        AIDeployment: Record "AI Deployment";
        IDeployment: Interface "IDeployment";
        Loaded: Boolean;




    procedure SetInterface(Deployment: Enum "AI Deployment")
    begin
        AIDeployment.Get(Deployment);
        IDeployment := Deployment;
        Loaded := true;
    end;

    procedure GetInterface() : Interface "IDeployment"
    begin
        if not Loaded then
            SetInterface(enum::"AI Deployment"::"gpt-4-32k");
        exit(IDeployment);
    end; 
    
    [NonDebuggable]
    procedure GetSecretKey() SecretKey: Text
    begin
        GetInterface();
        exit(AIDeployment.GetSecretKey());
    end;

    procedure GetDeployment() Deployment: Text
    begin
        exit(GetInterface().GetDeployment());
    end;

    procedure GetEndpoint() Endpoint: Text
    begin
        GetInterface();
        exit(AIDeployment.Endpoint);
    end;

}