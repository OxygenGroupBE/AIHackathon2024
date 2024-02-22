pageextension 53300 "BusinessManagerRoleCenter Ext" extends "Business Manager Role Center"
{
    actions
    {
        addfirst(embedding)
        {
            action(AIStudio)
            {
                ApplicationArea = All;
                Caption = 'AI Studio for BC';
                Image = Sparkle;
                Visible = true;
                RunObject = Page "AI Studio";
            }
        }
    }
}