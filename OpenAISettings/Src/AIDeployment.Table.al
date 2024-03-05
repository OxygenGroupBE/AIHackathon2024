table 56160 "AI Deployment"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Deployment"; enum "AI Deployment")
        {
            Caption = 'Deployment';
            DataClassification = CustomerContent;
        }
        field(2; "Description"; text[250])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(10; Endpoint; text[250])
        {
            Caption = 'Endpoint';
            DataClassification = CustomerContent;
        }
    }

    keys
    {
        key(PK; "Deployment")
        {
            Clustered = true;
        }
    }

    var
        IsolatedStorageSecretKeyKey: Label 'Copilot.AIStudioSecret.%1', Locked = true;

    [NonDebuggable]
    procedure SetSecretKey(SecretKey: Text)
    begin
        IsolatedStorage.Set(StrSubstNo(IsolatedStorageSecretKeyKey, Rec.Deployment.AsInteger()), SecretKey);
    end;

    [NonDebuggable]
    procedure GetSecretKey() SecretKey: Text
    begin
        IsolatedStorage.Get(StrSubstNo(IsolatedStorageSecretKeyKey, Rec.Deployment.AsInteger()), SecretKey);
    end;
}