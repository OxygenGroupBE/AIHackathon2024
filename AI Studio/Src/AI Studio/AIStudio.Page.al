namespace Copilot.AIStudio;

page 53300 "AI Studio"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    SourceTable = "AI Studio Attempt";
    SourceTableTemporary = true;
    ApplicationArea = All;
    UsageCategory = Administration;
    Caption = 'AI Studio for Copilot';

    // PromptMode = Content;
    // With PromptMode you can choose if the PromptDialog will open in:
    // - Prompt mode (ask the user for input)
    // - Generate mode (it will call the Generate system action the moment the page opens)
    // - Content mode ()
    // You can also programmaticaly set this property by setting the variable CurrPage.PromptMode before the page is opened.

    // SourceTable = ;
    // SourceTableTemporary = true;
    // You can have a source table for a PromptDialog page, as long as the source table is temporary. This is optional, though. 
    // The meaning of this source table is slightly different than for the other page types. In a PromptDialog page, the source table should represent an
    // instance of a copilot suggestion, that can include both the user inputs and the Copilot results. You should insert a new record each time the user
    // tries to regenerate a suggestion (before the page is closed and the suggestion saved). This way, the Business Central web client will show a new
    // history control, that allows the user to go back and forth between the different suggestions that Copilot provided, and choose the best one to save.

    layout
    {
        // In PromptDialog pages, you can define a PromptOptions area. Here you can add different settings to tweak the output that Copilot will generate.
        // These settings must be defined as page fields, and must be of type Option or Enum. You cannot define groups in this area.
        area(PromptOptions)
        {
            field(Deployment; TempAIStudioAttempt.Deployment)
            {
                Caption = 'Deployment';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }
        // The Prompt area is where the user can provide input for your Copilot feature. The PromptOptions area should contain fields that have a limited set of options,
        // whereas the Prompt area can contain more structured and powerful controls, such as free text controls and subparts with grids.
        area(Prompt)
        {
            field("Max. Tokens"; TempAIStudioAttempt."Max. Tokens")
            {
                Caption = 'Max. Tokens';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field("Temperature"; TempAIStudioAttempt."Temperature")
            {
                Caption = 'Temperature';
                ApplicationArea = All;
                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field(SystemPrompt; SystemPrompt)
            {
                Caption = 'System Prompt';
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
            field(UserPrompt; UserPrompt)
            {
                Caption = 'User Prompt';
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }

        // The Content area is the output of the Copilot feature. This can contain fields or parts, so that you can have all the flexibility you need to
        // show the user the suggestion that your Copilot feature generated.
        area(Content)
        {
            field(MaxTokensGiven; TempAIStudioAttempt."Max. Tokens")
            {
                Caption = 'Max. Tokens';
                ApplicationArea = All;
            }
            field(TemperatureGiven; TempAIStudioAttempt."Temperature")
            {
                Caption = 'Temperature';
                ApplicationArea = All;
            }
            field(Dev; TempAIStudioAttempt.Deployment)
            {
                Caption = 'Deployment';
                ApplicationArea = All;
                Editable = false;
            }
            group(Group)
            {
                ShowCaption = false;
                group(SystemPrompGiven)
                {
                    Caption = 'System Prompt';
                    field(SystemPrompGivenInput; SystemPrompt)
                    {
                        ApplicationArea = All;
                    }
                }
                group(UserPrompGiven)
                {
                    Caption = 'User Prompt';
                    field(UserPrompGivenInput; UserPrompt)
                    {
                        ApplicationArea = All;
                    }
                }
            }
            group(ResultControl)
            {
                Caption = 'Result';
                usercontrol(Result; "HTML Output_IFC")
                {
                    ApplicationArea = All;
                    trigger OnInitialized()
                    begin
                        ResultInitialized := true;

                        SetResultValue(Result);
                    end;
                }
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            // You can have custom behaviour for the main system actions in a PromptDialog page, such as generating a suggestion with copilot, regenerate, or discard the
            // suggestion. When you develop a Copilot feature, remember: the user should always be in control (the user must confirm anything Copilot suggests before any
            // change is saved).
            // This is also the reason why you cannot have a physical SourceTable in a PromptDialog page (you either use a temporary table, or no table).
            systemaction(Generate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate AI proposal with Dynamics 365 Copilot.';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Close';
                ToolTip = 'Close.';
            }
            systemaction(Regenerate)
            {
                Caption = 'Generate';
                ToolTip = 'Generate AI proposal with Dynamics 365 Copilot.';
                trigger OnAction()
                begin
                    Generate := true;
                    RunGeneration();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption := 'AI Studio for BC';
        CurrPage.PromptMode := PromptMode::Content;
    end;

    trigger OnAfterGetCurrRecord()
    begin
        GetValues();
    end;

    local procedure RunGeneration()
    var
        InStr: InStream;
        Attempts: Integer;
        Return: Text;
    begin
        NoOfAttempts += 1;
        Rec.Init();
        Rec.TransferFields(TempAIStudioAttempt);
        Rec.SetSystemPrompt(SystemPrompt);
        Rec.SetUserPrompt(UserPrompt);
        Rec.Attempt := NoOfAttempts;
        Rec.Insert();

        GenerateAI.SetPrompt(Rec);

        Attempts := 0;
        Return := '';
        while (Return = '') and (Attempts < 5) do begin
            if GenerateAI.Run() then begin
                Return := GenerateAI.GetResult();
            end;
            Attempts += 1;
        end;

        Rec.SetResult(Return);
        Rec.Modify();
        Commit();
        Generate := false;

        if (Attempts < 5) then
            CurrPage.Update(false)
        else
            Error('Something went wrong. Please try again. ' + GetLastErrorText());
    end;

    local procedure GetValues()
    begin
        if Generate then exit;
        SystemPrompt := Rec.GetSystemPrompt();
        UserPrompt := Rec.GetUserPrompt();
        Result := Rec.GetResult();
        SetResultValue(Result);
    end;

    var
        TempAIStudioAttempt: Record "AI Studio Attempt" temporary;
        GenerateAI: Codeunit "Generate AI";
        SystemPrompt, UserPrompt, Result : Text;
        NoOfAttempts: Integer;
        ResultInitialized, Generate : Boolean;
        mHtmlText: Text;

    procedure SetResultValue(HtmlText: Text)
    begin
        mHtmlText := HtmlText;
        if ResultInitialized then
            CurrPage.Result.SetHTMLValue(mHtmlText);
    end;
}