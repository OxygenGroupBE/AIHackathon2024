namespace AIHackathon.waldo.Copilot.Translations;

using Microsoft.Inventory.Item;
using System.Globalization;

page 55142 "Items Transl. AI Proposal Sub"
{
    PageType = ListPart;
    ApplicationArea = All;
    UsageCategory = Lists;
    SourceTable = "Item Translation AI Proposal";

    layout
    {
        area(Content)
        {
            repeater(ItemTranslationDetails)
            {
                Caption = '';
                ShowCaption = false;

                field(Select; Rec.Select)
                {
                    ApplicationArea = All;
                }
                field("No."; Rec."No.")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Original Description"; Rec."Original Description")
                {
                    ApplicationArea = All;
                    Visible = false;
                }
                field("Target Language"; Rec."Target Language")
                {
                    ApplicationArea = All;
                }
                field("Translated Description"; Rec."Translated Description")
                {
                    ApplicationArea = All;
                }
                field(Confidence; Rec.Confidence)
                {
                    ApplicationArea = All;
                    BlankZero = true;
                }
                field("Suggested Translation"; Rec."Suggested Translation")
                {
                    ApplicationArea = All;

                    trigger OnValidate()
                    begin
                        rec.Select := true;
                    end;
                }

            }
        }
    }

    procedure Load(var ItemTranslationAIProposal: Record "Item Translation AI Proposal" temporary)
    begin
        Rec.Reset();
        Rec.DeleteAll();

        ItemTranslationAIProposal.Reset();
        if ItemTranslationAIProposal.FindSet() then
            repeat
                Rec.Copy(ItemTranslationAIProposal, false);
                Rec.Insert();
            until ItemTranslationAIProposal.Next() = 0;

        CurrPage.Update(false);
    end;

    procedure SaveTranslationsForItem(Item: Record Item)
    var
        TranslationToBeSaved: Text;
        Language: Record Language;
    begin
        Rec.SetRange(Select, true);
        if Rec.FindSet() then
            repeat
                TranslationToBeSaved := Rec."Translated Description";
                if Rec."Suggested Translation" <> '' then
                    TranslationToBeSaved := Rec."Suggested Translation";

                Language.SetRange("Windows Language Name", Rec."Target Language");
                if Language.FindSet() then
                    repeat
                        SaveLanguage(Rec."No.", Language.Code, TranslationToBeSaved);
                    until language.next < 1;
            until Rec.Next() < 1;
    end;

    local procedure SaveLanguage(ItemNo: Code[20]; LanguageCode: Code[10]; TranslationToBeSaved: Text)
    var
        ItemTranslation: record "Item Translation";
    begin
        if not ItemTranslation.Get(ItemNo, '', LanguageCode) then begin
            ItemTranslation.Init();
            ItemTranslation."Item No." := ItemNo;
            ItemTranslation."Language Code" := LanguageCode;
            ItemTranslation.Insert(true);
        end;

        ItemTranslation.Description := TranslationToBeSaved;
        ItemTranslation.Modify(true);
    end;

}