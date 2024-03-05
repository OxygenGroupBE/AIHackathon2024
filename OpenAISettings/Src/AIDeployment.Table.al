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
        field(20; "Default"; Boolean)
        {
            Caption = 'Default';
            DataClassification = CustomerContent;
            trigger OnValidate()
            var
                AIDeployment: Record "AI Deployment";
            begin
                if not Default then exit;
                AIDeployment.SetFilter(Deployment, '<>%1', Rec.Deployment);
                AIDeployment.SetRange("Default", true);
                AIDeployment.ModifyAll("Default", false);
            end;
        }

    }

    keys
    {
        key(PK; "Deployment")
        {
            Clustered = true;
        }
        key(Default; "Default")
        { }
    }

    var
        IsolatedStorageSecretKeyKey: Label 'Copilot.AIStudioSecret.%1', Locked = true;

    procedure GetDefault(): enum "AI Deployment"
    var
        AIDeployment: Record "AI Deployment";
    begin
        AIDeployment.SetCurrentKey(Default);
        AIDeployment.SetRange(Default, true);
        AIDeployment.SetLoadFields(Deployment);
        if AIDeployment.FindFirst() then
            exit(AIDeployment.Deployment)
        else
            exit(AIDeployment.Deployment::"gpt-4-32k");
    end;

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