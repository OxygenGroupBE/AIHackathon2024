table 54324 "Copilot Data Verify Proposal"
{
    TableType = Temporary;

    fields
    {
        field(1; "Line No."; Integer)
        {
            Caption = 'Line No.';
            Editable = false;
        }
        field(3; "Table No."; Integer)
        {
            Caption = 'Table No.';
            Editable = false;
        }
        field(4; "Field No."; Integer)
        {
            Caption = 'Field No.';
            Editable = false;
            trigger OnValidate()
            begin
                CalcFields("Field Name");
            end;
        }
        field(5; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }
        field(6; Value; Text[100])
        {
            Caption = 'Value';
            trigger OnValidate()
            begin
                case true of
                    Rec.Value = '':
                        Action := enum::"Copilot Data Verify Action"::Ignore;
                    (Rec.Value <> xRec.Value) and (Rec.Value <> ''):
                        Action := enum::"Copilot Data Verify Action"::Update;
                end;
            end;
        }
        field(20; Explanation; Text[2048])
        {
            Caption = 'Explanation';
            Editable = false;
        }
        field(21; "Full Explanation"; Blob)
        {
            Caption = 'Full Explanation';
        }
        field(25; Action; enum "Copilot Data Verify Action")
        {
            Caption = 'Action';
        }
    }

    keys
    {
        key(Key1; "Line No.")
        {
            Clustered = true;
        }
    }
}