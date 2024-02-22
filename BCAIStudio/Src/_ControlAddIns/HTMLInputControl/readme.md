            group(UserControlGroup)
            {
                Caption = 'Text';
                usercontrol(ControlAddIn; "WYSIWYG Input Control")
                {
                    ApplicationArea = All;

                    trigger OnInitialized()
                    begin
                        mInitialized := true;
                        SetHTMLValue(mHtmlText);
                    end;

                    trigger SetReturnValue(ReturnHTML: Text)
                    begin
                        mInitialized := true;

                        mReturnHTML := ReturnHTML;
                        Currpage.Close();
                    end;

                }
            }