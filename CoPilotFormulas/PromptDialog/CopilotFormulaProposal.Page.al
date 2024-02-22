page 56200 "Copilot Formula Proposal"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Copilot Formula Proposal';

    layout
    {
        area(PromptOptions)
        {

        }
        area(Prompt)
        {
            field(ChatRequest; ChatRequest)
            {
                ShowCaption = false;
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    CurrPage.Update();
                end;
            }
        }

        area(Content)
        {
            part(SubsProposalSub; "Copilot Formula Proposal Sub")
            {
                ApplicationArea = All;
            }
        }
    }
    actions
    {
        area(SystemActions)
        {
            systemaction(Generate)
            {
                Caption = 'Generate';

                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
            systemaction(OK)
            {
                Caption = 'Confirm';
            }
            systemaction(Cancel)
            {
                Caption = 'Discard';
            }
            systemaction(Regenerate)
            {
                Caption = 'Regenerate';
                trigger OnAction()
                begin
                    RunGeneration();
                end;
            }
        }
    }

    trigger OnOpenPage()
    begin
        CurrPage.Caption := 'Calculates the selected formula';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CRP: Record "Copilot Formula Proposal";
    begin
        if CloseAction = CloseAction::OK then begin
            CurrPage.SubsProposalSub.Page.GetRecord(CRP);
            Gformula.Result := CRP.Result;
            Gformula.Modify();
        end;
    end;

    local procedure RunGeneration()
    var
        InStr: InStream;
        Attempts: Integer;
    begin
        CurrPage.Caption := ChatRequest;
        GenReminderProposal.SetUserPrompt(ChatRequest);
        GenReminderProposal.SetReminderLevel(Reminderlevel);

        TmpReminderAIProposal.Reset();
        TmpReminderAIProposal.DeleteAll();

        Attempts := 0;
        while TmpReminderAIProposal.IsEmpty and (Attempts < 5) do begin
            if GenReminderProposal.Run() then
                GenReminderProposal.GetResult(TmpReminderAIProposal);
            Attempts += 1;
        end;

        if (Attempts < 5) then begin
            Load(TmpReminderAIProposal);
        end else
            Error('Something went wrong. Please try again. ' + GetLastErrorText());
    end;

    procedure SetSourceItem(Formula: Record Formulas)
        Newline: Char;
    begin
        Gformula := Formula;
        Newline := 10;
        ChatRequest += 'The formula is: ' + Formula.Formula + Newline;
        ChatRequest += 'The list of parameters: ' + Formula.Parameters;
    end;

    procedure Load(var TmpFormulaAIProposal: Record "Copilot Formula Proposal" temporary)
    begin
        CurrPage.SubsProposalSub.Page.Load(TmpReminderAIProposal);

        CurrPage.Update(false);
    end;

    var
        SourceItem: Record Item;
        TmpReminderAIProposal: Record "Copilot Formula Proposal" temporary;
        GenReminderProposal: Codeunit "Generate Formula Proposal";
        ChatRequest: Text;
        Reminderlevel: Option first,second,last;
        Gformula: record Formulas;
}