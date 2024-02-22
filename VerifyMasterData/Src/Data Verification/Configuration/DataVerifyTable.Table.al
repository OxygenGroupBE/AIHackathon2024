
table 54300 "Data Verify Table"
{
    DataClassification = CustomerContent;
    Caption = 'Data Verify Table Configuration';

    fields
    {
        field(1; "Table No."; Integer)
        {
            Caption = 'Tabel No.';
            DataClassification = CustomerContent;
            TableRelation = AllObjWithCaption."Object ID" Where("Object Type" = Const(Table));
            trigger OnValidate()
            begin
                if not IsValidTableNo("Table No.") then
                    FieldError("Table No.");

                CalcFields("Table Name");
            end;

            trigger OnLookup()
            begin
                OnLookupTableNo();
            end;
        }

        field(3; "Table Name"; Text[30])
        {
            Caption = 'Table Name';
            FieldClass = FlowField;
            CalcFormula = Lookup(AllObjWithCaption."Object Name" where("Object Type" = const(Table), "Object ID" = field("Table No.")));
            Editable = false;
        }
        field(10; "Sampling"; Integer)
        {
            Caption = 'Sampling';
            DataClassification = CustomerContent;
            InitValue = 20;
        }

        field(20; "No. Of Skipped Fields"; Integer)
        {
            Caption = 'No. Of Skipped Fields';
            FieldClass = FlowField;
            CalcFormula = count("Data Verify Table Field" where("Table No." = field("Table No.")));
            Editable = false;

        }
    }

    keys
    {
        key(PK; "Table No.")
        {
            Clustered = true;
        }
    }

    trigger OnDelete()
    var
        DataVerifyTableField: record "Data Verify Table Field";

    begin
        DataVerifyTableField.SetRange(DataVerifyTableField."Table No.", Rec."Table No.");
        DataVerifyTableField.DeleteAll(false);
    end;

    local procedure IsValidTableNo(TableNo: integer): Boolean
    var
        AllObject: record AllObjWithCaption;
    begin
        AllObject.SetRange(AllObject."Object Type", AllObject."Object Type"::Table);
        AllObject.Setfilter(AllObject."Object ID", GetTableIDFilter());
        if AllObject.Findset(false) then
            repeat
                if TableNo = AllObject."Object ID" then
                    exit(true);
            until AllObject.Next() = 0;
        exit(false);

    end;

    local procedure GetTableIDFilter(): Text
    var
        TableIDFilter: text;
    begin
        AddTableIDToFilter(DATABASE::Customer, TableIDFilter);
        AddTableIDToFilter(DATABASE::Vendor, TableIDFilter);
        AddTableIDToFilter(DATABASE::Item, TableIDFilter);
        AddTableIDToFilter(DATABASE::Contact, TableIDFilter);
        EXIT(TableIDFilter);
    end;


    local procedure AddTableIDToFilter(TableID: Integer; VAR TableIDFilter: Text)
    var
    begin
        if TableID = 0 then exit;

        if TableIDFilter <> '' then
            TableIDFilter += '|';

        TableIDFilter += FORMAT(TableID);
    end;

    local procedure OnLookupTableNo()
    var
    begin
        Validate("Table No.", LookUpTableNo(GetTableIDFilter(), "Table No."));
    end;

    local procedure LookUpTableNo(TableIdFilter: text; DefaultTableId: integer): integer
    var
        AllObject: record AllObjWithCaption;
    begin
        AllObject.FilterGroup(2);
        AllObject.SetRange(AllObject."Object Type", AllObject."Object Type"::Table);
        if TableIDFilter <> '' then
            AllObject.SetFilter(AllObject."Object ID", TableIDFilter);
        AllObject.FilterGroup(0);
        if Page.RunModal(Page::Objects, AllObject) = Action::LookupOK then
            exit(AllObject."Object ID")
        else
            exit(DefaultTableID);
    end;

}