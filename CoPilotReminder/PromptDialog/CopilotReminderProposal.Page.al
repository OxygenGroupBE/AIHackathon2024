page 56000 "Copilot Reminder Proposal"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Copilot Reminder Proposal';

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

        // The Prompt area is where the user can provide input for your Copilot feature. The PromptOptions area should contain fields that have a limited set of options,
        // whereas the Prompt area can contain more structured and powerful controls, such as free text controls and subparts with grids.
        area(PromptOptions)
        {
            field(reminderlevel; Reminderlevel)
            {
                ApplicationArea = All;
            }
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

        // The Content area is the output of the Copilot feature. This can contain fields or parts, so that you can have all the flexibility you need to
        // show the user the suggestion that your Copilot feature generated.
        area(Content)
        {
            part(SubsProposalSub; "Copilot Reminder Proposal Sub")
            {
                ApplicationArea = All;
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
        CurrPage.Caption := 'Suggest reminder for selected customer with Copilot';
    end;

    trigger OnQueryClosePage(CloseAction: Action): Boolean
    var
        CRP: Record "Copilot Reminder Proposal";
    begin
        if CloseAction = CloseAction::OK then begin
            CurrPage.SubsProposalSub.Page.GetRecord(CRP);
            CurrPage.SubsProposalSub.Page.SetReminderEmailProprosal(CRP);
            CurrPage.SubsProposalSub.Page.SendReminderEmail();
        end;
    end;

    trigger OnClosePage()
    var
        CRP: Record "Copilot Reminder Proposal";
    begin
        // CurrPage.SubsProposalSub.Page.GetRecord(CRP);
        // CurrPage.SubsProposalSub.Page.SetReminderEmailProprosal(CRP);
        //CurrPage.SubsProposalSub.Page.SendReminderEmail();
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

    procedure SetSourceItem(Customer: Record Customer)
    begin
        //SourceItem := Item2;
        ChatRequest := Customer."No.";
    end;

    procedure Load(var TmpReminderAIProposal: Record "Copilot Reminder Proposal" temporary)
    begin
        CurrPage.SubsProposalSub.Page.Load(TmpReminderAIProposal);

        CurrPage.Update(false);
    end;

    var
        SourceItem: Record Item;
        TmpReminderAIProposal: Record "Copilot Reminder Proposal" temporary;
        GenReminderProposal: Codeunit "Generate Reminder Proposal";
        ChatRequest: Text;
        Reminderlevel: Option first,second,last;
}