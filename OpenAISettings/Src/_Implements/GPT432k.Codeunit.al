codeunit 56161 "GPT-4-32k" implements "IDeployment"
{
    procedure GetDeployment() Deployment: Text;
    begin
        exit('gpt-4-32k');
    end;
}