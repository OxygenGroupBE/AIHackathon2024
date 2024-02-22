namespace AIHackathon.waldo.Copilot.Translations;

using AIHackathon.waldo.Copilot.Translations;
using System.Globalization;
using Microsoft.Inventory.Item;

codeunit 55145 "Generate Item Transl. Proposal"
{
    var
        Item: Record Item;
        TmpItemTranslationAIProposal: Record "Item Translation AI Proposal" temporary;

    trigger OnRun()
    begin
        GenerateProposal;
    end;

    procedure SetItem(var pItem: Record Item)
    begin
        Item := pItem;
        Item.CopyFilters(pItem);
    end;

    procedure GetResult(var TmpItemTranslationAIProposal2: Record "Item Translation AI Proposal" temporary)
    begin
        TmpItemTranslationAIProposal2.Copy(TmpItemTranslationAIProposal, true);
    end;

    local procedure GenerateProposal()
    var
        ItemTranslation: Record "Item Translation";
        DiscoverLangCopilot: Codeunit DiscoverLangCopilot;
        AssumedLanguage: Text;
    begin
        AssumedLanguage := DiscoverLangCopilot.Discover(Item.Description);
        if AssumedLanguage = 'Unknown' then
            AssumedLanguage := 'Dutch'; //TODO: This is a default that should be configurable

        ItemTranslation.SetRange("Item No.", Item."No.");
        if ItemTranslation.FindSet() then
            repeat
                CheckItemTranslation(Item, ItemTranslation);
            until ItemTranslation.Next < 1;

        //TODO: Setup to configure requested languages
        AddLanguageIfNecessary(Item, 'Dutch (Belgium)', AssumedLanguage);
        AddLanguageIfNecessary(Item, 'English (United States)', AssumedLanguage);
        AddLanguageIfNecessary(Item, 'French (France)', AssumedLanguage);
    end;

    local procedure CheckItemTranslation(var Item: Record Item; var ItemTranslation: Record "Item Translation")
    var
        CheckTranslationCopilot: Codeunit "Check Translation Copilot";
        Confidence: Decimal;
        TargetLanguage: Text;
        TranslatedText: Text;
    begin
        TranslatedText := ItemTranslation.Description;
        TargetLanguage := GetFullLanguageName(ItemTranslation."Language Code");

        Confidence := CheckTranslationCopilot.CheckTranslation(Item.Description, TranslatedText, TargetLanguage.split(' ').get(1));

        AddTranslationProposalIfNecessary(Item, TargetLanguage, ItemTranslation.Description, TranslatedText, Confidence);
    end;

    local procedure AddTranslationProposalIfNecessary(var Item: Record Item; TargetLanguage: Text; TranslDescription: Text; SuggestedDescription: Text; Confidence: Decimal)
    begin
        TmpItemTranslationAIProposal.SetRange("No.", Item."No.");
        TmpItemTranslationAIProposal.SetRange("Target Language", TargetLanguage);
        if not TmpItemTranslationAIProposal.IsEmpty() then exit;

        TmpItemTranslationAIProposal.PrimaryKey := CreateGuid();
        TmpItemTranslationAIProposal."No." := Item."No.";
        TmpItemTranslationAIProposal."Original Description" := Item.Description;
        TmpItemTranslationAIProposal."Target Language" := TargetLanguage;
        TmpItemTranslationAIProposal."Translated Description" := TranslDescription;
        if TranslDescription <> SuggestedDescription then
            TmpItemTranslationAIProposal."Suggested Translation" := SuggestedDescription;
        TmpItemTranslationAIProposal.Confidence := Confidence;
        TmpItemTranslationAIProposal.Insert();
    end;

    local procedure GetFullLanguageName(LanguageCode: code[10]): Text
    var
        language: record Language;
    begin
        Language.SetAutoCalcFields("Windows Language Name");
        language.Get(LanguageCode);
        // exit(language."Windows Language Name".Split(' ').get(1))
        exit(language."Windows Language Name")
    end;

    local procedure AddLanguageIfNecessary(var Item: Record Item; LanguageText: Text; AssumedLanguage: Text)
    var
        TranslateCopilot: Codeunit "Translate With Copilot";
        translatedText: Text;
    begin
        if LanguageText.Contains(AssumedLanguage) then begin
            translatedText := item.Description;
            AddTranslationProposalIfNecessary(Item, LanguageText, '', translatedText, 0);

            exit;
        end;

        TmpItemTranslationAIProposal.SetRange("No.", Item."No.");
        TmpItemTranslationAIProposal.SetRange("Target Language", LanguageText);
        if not TmpItemTranslationAIProposal.IsEmpty then exit;

        TranslatedText := TranslateCopilot.Translate(Item.Description, LanguageText.Split(' ').get(1));

        AddTranslationProposalIfNecessary(Item, LanguageText, '', translatedText, 0);
    end;
}
