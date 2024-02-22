namespace AIHackathon.waldo.Copilot.Translations;

using AIHackathon.waldo.Copilot.Translations;
using Microsoft.Inventory.Item;

pageextension 55141 "Item Card Ext" extends "Item Card"
{
    actions
    {
        addlast(Functions)
        {
            action(HandleTranslationsWithCopilot)
            {
                Caption = 'Handle Translations with Copilot';
                image = Sparkle;
                ApplicationArea = All;

                trigger OnAction()
                var
                    ItemTranslationCopilot: Page "Item Translation Copilot";
                begin
                    ItemTranslationCopilot.SetSourceItem(Rec);
                    ItemTranslationCopilot.RunModal();
                end;
            }
        }
        addfirst(Promoted)
        {
            actionref(HandleTranslationsWithCopilotRef; "HandleTranslationsWithCopilot") { }
        }
    }
}