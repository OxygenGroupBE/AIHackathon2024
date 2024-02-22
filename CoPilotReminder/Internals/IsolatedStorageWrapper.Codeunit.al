codeunit 56002 "Isolated Storage Wrapper"
{
    SingleInstance = true;
    Access = Internal;

    var
        ReminderMailSecretKeyKey: Label 'ReminderMailSecret', Locked = true;
        ReminderMailDeploymentKey: Label 'ReminderMailDeployment', Locked = true;
        ReminderMailEndpointKey: Label 'ReminderMailEndpoint', Locked = true;

    procedure GetSecretKey() SecretKey: Text
    begin
        IsolatedStorage.Get(ReminderMailSecretKeyKey, SecretKey);
    end;

    procedure GetDeployment() Deployment: Text
    begin
        IsolatedStorage.Get(ReminderMailDeploymentKey, Deployment);
    end;

    procedure GetEndpoint() Endpoint: Text
    begin
        IsolatedStorage.Get(ReminderMailEndpointKey, Endpoint);
    end;

    procedure SetSecretKey(SecretKey: Text)
    begin
        IsolatedStorage.Set(ReminderMailSecretKeyKey, SecretKey);
    end;

    procedure SetDeployment(Deployment: Text)
    begin
        IsolatedStorage.Set(ReminderMailDeploymentKey, Deployment);
    end;

    procedure SetEndpoint(Endpoint: Text)
    begin
        IsolatedStorage.Set(ReminderMailEndpointKey, Endpoint);
    end;

}