page 56201 Formulas
{
    ApplicationArea = All;
    Caption = 'Formulas';
    PageType = List;
    SourceTable = Formulas;
    UsageCategory = Administration;

    layout
    {
        area(content)
        {
            repeater(General)
            {
                field(EntryNo; Rec.EntryNo)
                {
                    ToolTip = 'Specifies the value of the EntryNo field.';
                }
                field(Formula; Rec.Formula)
                {
                    ToolTip = 'Specifies the value of the Formula field.';
                }
                field(Parameters; Rec.Parameters)
                {
                    ToolTip = 'Specifies the value of the Parameters field.';
                }
                field(Result; Rec.Result)
                {
                    ToolTip = 'Specifies the value of the Result field.';
                }
            }
        }


    }
    actions
    {
        area(Processing)
        {
            action(GenerateCopilot)
            {
                Caption = 'Calculate with Copilot';
                Image = Sparkle;
                ApplicationArea = All;
                ToolTip = 'Lets Copilot calculate the given formula.';

                trigger OnAction()
                var
                    CopilotCalculateFormulaPage: page "Copilot Formula Proposal";
                begin
                    CopilotCalculateFormulaPage.SetSourceItem(Rec);
                    CopilotCalculateFormulaPage.Run();
                    CurrPage.Update(false);
                end;
            }
        }
    }
}
