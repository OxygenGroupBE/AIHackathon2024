table 53300 "AI Studio Attempt"
{
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Attempt"; Integer)
        {
            Caption = 'Attempt';
        }
        field(2; "Deployment"; enum "Al Studio Deployment")
        {
            Caption = 'Deployment';
        }
        field(10; "System Prompt"; Blob)
        {
            caption = 'System Prompt';
        }
        field(20; "User Prompt"; Blob)
        {
            caption = 'User Prompt';
        }
        field(30; Result; Blob)
        {
            caption = 'Result';
        }
        field(40; "Temperature"; Integer)
        {
            Caption = 'Temperature';
        }
        field(50; "Max. Tokens"; Integer)
        {
            Caption = 'Max. Tokens';
            InitValue = 2500;
        }
    }

    keys
    {
        key(PK; "Attempt")
        {
            Clustered = true;
        }
    }


    procedure SetSystemPrompt(Value: Text)
    var
        OutStr: OutStream;
    begin
        Rec."System Prompt".CreateOutStream(OutStr);
        OutStr.WriteText(Value);
    end;

    procedure GetSystemPrompt() Value: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        Rec.CalcFields("System Prompt");
        Rec."System Prompt".CreateInStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, ''));
    end;

    procedure SetUserPrompt(Value: Text)
    var
        OutStr: OutStream;
    begin
        Rec."User Prompt".CreateOutStream(OutStr);
        OutStr.WriteText(Value);
    end;

    procedure GetUserPrompt() Value: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        Rec.CalcFields("User Prompt");
        Rec."User Prompt".CreateInStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, ''));
    end;

    procedure SetResult(Value: Text)
    var
        OutStr: OutStream;
    begin
        Rec.Result.CreateOutStream(OutStr);
        OutStr.WriteText(Value);
    end;

    procedure GetResult() Value: Text
    var
        TypeHelper: Codeunit "Type Helper";
        InStr: InStream;
    begin
        Rec.CalcFields("Result");
        Rec.Result.CreateInStream(InStr);
        exit(TypeHelper.ReadAsTextWithSeparator(InStr, ''));
    end;
}