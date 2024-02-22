table 56201 "Copilot Formula Proposal"
{
    TableType = Temporary;

    fields
    {
        field(1; EntryNo; BigInteger)
        {
            Caption = 'EntryNo';
            Editable = false;
        }
        field(2; Formula; Text[2048])
        {
            Caption = 'Formula';
            Editable = false;
        }
        field(3; Parameters; Text[2048])
        {
            Caption = 'Parameters';
            Editable = false;
        }
        field(4; Result; Text[2048])
        {
            Caption = 'Result';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; EntryNo)
        {
            Clustered = true;
        }
    }
}