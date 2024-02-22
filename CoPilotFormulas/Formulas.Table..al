table 56200 Formulas
{
    DataClassification = ToBeClassified;

    fields
    {
        field(56200; EntryNo; BigInteger)
        {
            DataClassification = ToBeClassified;
            AutoIncrement = true;
        }
        field(56210; Formula; text[2048])
        {
            DataClassification = ToBeClassified;
        }
        field(56220; Parameters; text[2048])
        {
            DataClassification = ToBeClassified;
        }
        field(56230; Result; Text[2048])
        {
            DataClassification = ToBeClassified;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
        // Add changes to field groups here
    }

    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}