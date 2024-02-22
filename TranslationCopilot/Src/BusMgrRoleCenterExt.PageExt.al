pageextension 55140 BusMgrRoleCenterExt extends "Business Manager Role Center"
{
    actions
    {
        addfirst(embedding)
        {
            action(TranslateWithCopilot)
            {
                ApplicationArea = All;
                Image = Sparkle;
                Caption = 'Translate with Copilot';
                ToolTip = 'Translate with Copilot';
                RunObject = page "Translate with Copilot";
            }
        }
    }
}