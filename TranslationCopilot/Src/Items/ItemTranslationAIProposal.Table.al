
namespace AIHackathon.waldo.Copilot.Translations;

table 55140 "Item Translation AI Proposal"
{
    TableType = Temporary;

    fields
    {
        field(100; PrimaryKey; Guid)
        {
            Caption = 'Primary Key';
            Editable = false;
        }
        field(1; Select; Boolean)
        {
            Caption = 'Select';
            Editable = true;
        }
        field(2; "No."; Code[20])
        {
            Caption = 'No.';
            Editable = false;
        }
        field(3; "Original Description"; Text[100])
        {
            Caption = 'Description';
            Editable = false;
        }
        field(4; "Target Language"; Text[100])
        {
            Caption = 'Target Language';
            Editable = false;
        }
        field(5; "Translated Description"; Text[100])
        {
            Caption = 'Translated Description';
            Editable = false;
        }
        field(6; "Suggested Translation"; Text[100])
        {
            Caption = 'Suggested Translation';
            Editable = true;
        }
        field(7; "Confidence"; Decimal)
        {
            Caption = 'Confidence';
            Editable = false;
        }

    }

    keys
    {
        key(PK; PrimaryKey)
        {
            Clustered = true;
        }
    }
}