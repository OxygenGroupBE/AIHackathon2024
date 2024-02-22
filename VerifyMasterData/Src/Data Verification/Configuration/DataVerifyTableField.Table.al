table 54301 "Data Verify Table Field"
{
    DataClassification = CustomerContent;
    Caption = 'Data Verify Fields Configuration';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Table No.';
            DataClassification = CustomerContent;
            trigger OnValidate()
            begin
                CalcFields("Table Name");
                IF "Table No." <> xRec."Table No." THEN
                    "Field No." := 0;
            end;
        }

        field(3; "Field No."; Integer)
        {
            Caption = 'Field No.';
            DataClassification = CustomerContent;
            TableRelation = Field."No." WHERE(TableNo = FIELD("Table No."), Type = FILTER(Code | Text), Class = const(Normal));
            trigger OnValidate()
            begin
                ThrowErrorIfInvalidFieldNo();
                CalcFields("Field Name");
            end;

            trigger OnLookup()
            begin
                Validate("Field No.", LookUpFieldNo("Table No.", "Field No."));
            end;
        }

        field(4; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }

        field(5; "Field Name"; Text[30])
        {
            Caption = 'Field Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(Field.FieldName where(TableNo = field("Table No."), "No." = field("Field No.")));
            Editable = false;
        }

    }

    keys
    {
        key(PK; "Table No.", "Field No.")
        {
            Clustered = true;
        }
    }

    trigger OnRename()
    var
        RenameNotAllowedErr: Label 'You can not rename this record.';
    begin
        Error(RenameNotAllowedErr);
    end;


    procedure ThrowErrorIfInvalidFieldNo()
    begin
        IF "Field No." = 0 THEN
            FieldError("Field No.");
    end;


    procedure LookUpFieldNo(TableIdFilter: Integer; DefaultFieldId: Integer): integer
    var
        FieldRec: Record Field;
        FieldSelection: Codeunit "Field Selection";
    begin
        FieldRec.FilterGroup(2);
        FieldRec.SetRange(FieldRec.TableNo, TableIdFilter);
        FieldRec.SetFilter(FieldRec.Type, '%1|%2|%3|%4|%5', FieldRec.Type::Code, FieldRec.Type::text, FieldRec.Type::Date, FieldRec.Type::Datetime, FieldRec.Type::Time);
        FieldRec.FilterGroup(0);
        if not FieldSelection.Open(FieldRec) then exit(DefaultFieldId);
        exit(FieldRec."No.")
    end;
}