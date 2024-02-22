namespace AIHackathon.waldo.Copilot.Translations;

using AIHackathon.waldo.Copilot.Translations;

page 55140 "Translate with Copilot"
{
    PageType = PromptDialog;
    Extensible = false;
    IsPreview = true;
    Caption = 'Translate with Copilot';

    layout
    {
        area(Content)
        {
            field(TranslationRequest; TranslationRequest)
            {
                Caption = 'Source';
                MultiLine = true;
                ApplicationArea = All;

                trigger OnValidate()
                begin
                    DiscoverLanguage();
                end;
            }
            field(TranslaterFrom; TranslateFrom)
            {
                Caption = 'Translate from';
                ApplicationArea = All;
            }
            field(TranslateTo; TranslateTo)
            {
                Caption = 'Translate to';
                ApplicationArea = All;
            }
            Field(Translated; TranslatedText)
            {
                Caption = 'Translated';
                MultiLine = true;
                ApplicationArea = All;
            }
        }
        area(PromptOptions)
        {

        }
    }

    actions
    {
        area(SystemActions)
        {
            systemaction(Attach)
            {
                Caption = 'Discover language';
                Tooltip = 'Discover the language of the text';

                trigger OnAction()
                begin
                    DiscoverLanguage();
                end;
            }
            systemaction(Regenerate)
            {
                Caption = 'Translate';
                Tooltip = 'Translate the text';

                trigger OnAction()
                begin
                    Translate();
                end;
            }
        }
    }

    var
        TranslationRequest: Text;
        TranslateFrom: Text;
        TranslateTo: Text;
        TranslatedText: Text;
        DiscoverLangCopilot: Codeunit DiscoverLangCopilot;
        TranslateCopilot: Codeunit "Translate With Copilot";

    trigger OnOpenPage()
    begin
        // TranslationRequest := 'นี่เป็นการทดสอบ'; // for test
        DiscoverLanguage();
        TranslateTo := 'English';

        CurrPage.PromptMode := PromptMode::Content;
    end;

    local procedure DiscoverLanguage()
    var
        InStr: InStream;
        Attempts: Integer;
    begin
        TranslateFrom := DiscoverLangCopilot.Discover(TranslationRequest)
    end;

    local procedure Translate()
    var
        InStr: InStream;
        Attempts: Integer;
    begin
        TranslatedText := TranslateCopilot.Translate(TranslationRequest, TranslateTo);
    end;

}