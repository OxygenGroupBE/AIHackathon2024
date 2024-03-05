codeunit 56160 "GPT-35-turbo" implements "IDeployment"
{
    procedure GetDeployment() Deployment: Text;
    begin
        exit('gpt-35-turbo');
    end;
}