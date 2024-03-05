codeunit 56162 "AI Deployment Factory"
{
    SingleInstance = true;


    var
        AIDeployment: Record "AI Deployment";
        Loaded: Boolean;


    procedure SetInterface(Deployment: Enum "AI Deployment")
    begin
        AIDeployment.Get(Deployment);
        Loaded := true;
    end;

    procedure GetInterface(): Record "AI Deployment"
    begin
        if not Loaded then
            SetInterface(AIDeployment.GetDefault());

        exit(AIDeployment);
    end;

    [NonDebuggable]

    procedure GetSecretKey() SecretKey: Text
    begin
        exit(GetInterface().GetSecretKey());
    end;

    procedure GetDeployment() Deployment: Text
    var
        enumValue: Integer;
    begin
        enumValue := enum::"AI Deployment".Ordinals().IndexOf(AIDeployment.Deployment.AsInteger());
        exit(enum::"AI Deployment".Names().Get(enumValue));
    end;
    
        procedure GetEndpoint() Endpoint: Text
    begin
        exit(GetInterface().Endpoint);
    end;

}