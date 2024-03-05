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
                    Rec.Deployment := TempAIStudioAttempt.Deployment;
                    Rec.Modify();
                    
                    CurrPage.Update();
                end;
            }
        }
        // The Prompt area is where the user can provide input for your Copilot feature. The PromptOptions area should contain fields that have a limited set of options,
        // whereas the Prompt area can contain more structured and powerful controls, such as free text controls and subparts with grids.

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
            field(Dev; Rec.Deployment)
                    {
                Caption = 'Deployment';
                ApplicationArea = All;
                Editable = false;
            }
            group(Group)
            {
                Caption = 'Prompts';
                group(SystemPrompGiven)
                {
                    Caption = 'System';
                    field(SystemPrompGivenInput; SystemPrompt)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ShowCaption = false;
                        trigger OnAssistEdit()
                        begin
                            Message(SystemPrompt);
                        end;
                    }
                }
                group(UserPrompGiven)
                {
                    Caption = 'User';
                    field(UserPrompGivenInput; UserPrompt)
                    {
                        ApplicationArea = All;
                        MultiLine = true;
                        ShowCaption = false;
                        trigger OnAssistEdit()
                        begin
                            Message(UserPrompt);
                        end;
                    }
                }
            }
            group(Count)
            {
                field("Approximate Tokens"; Rec."Approximate Tokens")
                {
                    Caption = 'Approximate Tokens';
                }
                field("Precise Tokens"; Rec."Precise Tokens")
                {
                    Caption = 'Precise Tokens';
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

        AddDemoData();
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
        Rec."Approximate Tokens" := Rec.ApproximateTokenCount(SystemPrompt + UserPrompt);
        Rec."Precise Tokens" := Rec.PreciseTokenCount(SystemPrompt + UserPrompt);
        Rec.Attempt := NoOfAttempts;
        Rec.Insert();
        Commit();

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
        TempAIStudioAttempt.TransferFields(Rec);
        SetResultValue(Result); 
    end;

    local procedure AddDemoData()
    var
        AIDeployment: Record "AI Deployment";
    begin
        Rec.Init();
        rec.Attempt := 1;
        Rec.SetSystemPrompt('The father of Jack has three sons.  The user will provide you 2 names.you need to find the third name.');
        rec.SetUserPrompt('The 3 sons are called "Pief", "Poef" and ..');
        Rec.Deployment := AIDeployment.GetDefault();
        Rec.Insert();

        Rec.Init();
        rec.Attempt := 2;
        Rec.SetSystemPrompt('The user will ask a joke, you need to tell one.');
        rec.SetUserPrompt('Tell me a joke of the day');
        Rec.Deployment := AIDeployment.GetDefault();
        rec.Insert();

        Rec.Init();
        rec.Attempt := 3;
        Rec.SetSystemPrompt('The user will provide an item with all fields, and a list of reference items. Your task is suggest values for missing values in fields to the majority of the reference items and suggest a value. '
            + 'The available fields are delimited by |  '
            + 'The following lines should contain the values of the fields.'
            + 'For example: '
            + 'These are the available items:'
            + '1=''A''|3=''df''|4=''ST''|9=''''|10=''DG'''
            + '1=''B''|3=''gd''|4=''DS''|9=''''|10=''DG'''
            + '1=''C''|3=''xa''|4=''DS''|9=''''|10=''DG'''
            + 'The current item that needs to be checked is: 1=''D''|3=''''|4=''ST''|9=''uy''|10=''DG'''
            + 'The result will be:'
            + 'fieldno: 3, value: MISSING, explanation: The field is not empty in the majority of the items.'
            + 'The output should be in xml, containing field (use fieldno tag), value (use value tag), and explanation why this field was suggested (use explanation tag).'
            + 'Use items as a root level tag, use item as item tag.'
            + 'Do not use line breaks or other special characters in explanation.'
            + 'Skip empty nodes.'
            );
        rec.SetUserPrompt('These are the available items:'
            + '1=''1900-S''|2=''''|3=''PARIJS Bezoekersstoel, zwart''|4=''PARIJS BEZOEKERSSTOEL, ZWART''|5=''''|8=''STUKS''|11=''WEDERVERK''.'
            + '1=''1906-S''|2=''''|3=''ATHENE Mobiel onderstel''|4=''ATHENE MOBIEL ONDERSTEL''|5=''''|8=''STUKS''|11=''WEDERVERK''.'
            + '1=''1908-S''|2=''''|3=''LONDEN Draaistoel, blauw''|4=''LONDEN DRAAISTOEL, BLAUW''|5=''''|8=''STUKS''|11=''WEDERVERK''.'
            + '1=''1920-S''|2=''''|3=''ANTWERPEN Vergadertafel''|4=''ANTWERPEN VERGADERTAFEL''|5=''''|8=''STUKS''|11=''WEDERVERK''.'
            + '1=''1925-W''|2=''''|3=''Vergaderpakket 1-6''|4=''VERGADERPAKKET 1-6''|5=''''|8=''STUKS''|11=''WEDERVERK''.'
            + ' '
            + 'The current item that needs to be checked is: '
            + '1=''1896-S''|2=''''|3=''ATHENE Tafel''|4=''ATHENE TAFEL''|5=''''|8=''STUKS''|11=''TEST''.');
        Rec.Deployment := AIDeployment.GetDefault();
        Rec.Insert();

        Rec.Get(1);

        NoOfAttempts := 3;
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