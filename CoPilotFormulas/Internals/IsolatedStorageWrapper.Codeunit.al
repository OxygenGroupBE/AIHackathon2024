codeunit 56202 "Isolated Storage Wrapper"
{
    SingleInstance = true;
    Access = Internal;

    var
        FormulasSecretKeyKey: Label 'FormulasSecret', Locked = true;
        FormulasDeploymentKey: Label 'FormulasDeployment', Locked = true;
        FormulasEndpointKey: Label 'FormulasEndpoint', Locked = true;

    procedure GetSecretKey() SecretKey: Text
    begin
        IsolatedStorage.Get(FormulasSecretKeyKey, SecretKey);
    end;

    procedure GetDeployment() Deployment: Text
    begin
        IsolatedStorage.Get(FormulasDeploymentKey, Deployment);
    end;

    procedure GetEndpoint() Endpoint: Text
    begin
        IsolatedStorage.Get(FormulasEndpointKey, Endpoint);
    end;

    procedure SetSecretKey(SecretKey: Text)
    begin
        IsolatedStorage.Set(FormulasSecretKeyKey, SecretKey);
    end;

    procedure SetDeployment(Deployment: Text)
    begin
        IsolatedStorage.Set(FormulasDeploymentKey, Deployment);
    end;

    procedure SetEndpoint(Endpoint: Text)
    begin
        IsolatedStorage.Set(FormulasEndpointKey, Endpoint);
    end;

}