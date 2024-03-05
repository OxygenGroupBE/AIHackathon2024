enum 56160 "AI Deployment" implements IDeployment
{
    Extensible = true;

    value(0; "gpt-4-32k")
    {
        Caption = 'GPT-4 32k';
        Implementation = IDeployment = "GPT-4-32k";
    }
    value(1; "gpt-35-turbo")
    {
        Caption = 'GPT-3.5 Turbo';
        Implementation = IDeployment = "GPT-35-turbo";
    }
}