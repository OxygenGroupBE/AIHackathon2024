page 56160 "AI Deployment List"
{
    Caption = 'AI Deployment Settings';
    PageType = List;
    UsageCategory = Administration;
    ApplicationArea = All;
    SourceTable = "AI Deployment";

    layout
    {
        area(Content)
        {
            repeater(Group)
            {

                field(Deployment; Rec.Deployment)
                {
                    ToolTip = 'Specifies the value of the Deployment field.';
                }
                field(Description; Rec.Description)
                {
                    ToolTip = 'Specifies the value of the Description field.';
                }
                field(Endpoint; Rec.Endpoint)
                {
                    ToolTip = 'Specifies the value of the Endpoint field.';
                }
                field(SecretKey; SecretKey)
                {
                    Caption = 'Secret Key';
                    ToolTip = 'Specifies';
                    ExtendedDatatype = Masked;
                    trigger OnValidate()
                    begin
                        Rec.SetSecretKey(SecretKey);
                    end;
                }
            }
        }
    }

    var
        SecretKey: Text;
}