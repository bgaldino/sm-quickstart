import { LightningElement, track ,api ,wire} from 'lwc';
import isEmailExist from '@salesforce/apex/CommunityAuthController.isEmailExist';
import registerUser from '@salesforce/apex/CommunityAuthController.registerUser';
import { listContent } from 'lightning/cmsDeliveryApi';
import community_Id from '@salesforce/community/Id';
import selfLogin from '@salesforce/label/c.Self_Login_Url';
import basePathName from '@salesforce/community/basePath';

export default class RegisterComponent extends LightningElement {

    @track firstName = null;
    @track lastName = null;
    @track email = null;
    @track userName = null;
    @track password = null;
    @track confirmPassword = null;
    @track errorCheck;
    @track errorMessage;
    showUserName;
    @track showTermsAndConditions;
    @track showTermsAndConditionsLoading = false;
    @track infoTooltipDisplayData = {};
    @track requiredTooltipDisplayData = {};
    @track errorTooltipDisplayData = {};
    @track emailError;
    communityName = basePathName;
    @track passwordError;
    selfLogin = selfLogin;
    contentKeys = [undefined];
    @api get cmsContentId() {
        return this.contentKeys[0];
    }
    set cmsContentId(id) {

        if(!this.communityName.startsWith('/s/')){

            let text = this.communityName;
            let result = text.indexOf("/s/");
            let community_name = text.substring(0, result);
            this.contentKeys = community_name + '/cms/delivery/media/'+[id];
            
         }else{

            this.contentKeys = '/cms/delivery/media/'+[id];


         }

    }
         
    @wire(listContent, { communityId: community_Id, contentKeys: '$contentKeys' })
    onListContent(results) {
        console.log('System img',JSON.stringify(results.data));
        const content = results.data;}


    connectedCallback(){

        this.showUserName = false;

        this.infoTooltipDisplayData.username = "tooltiptext usernameTooltiptext";
        this.infoTooltipDisplayData.password = "tooltiptext";

        this.requiredTooltipDisplayData.firstName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.lastName = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.username = 'tooltiptext tooltipHide';        
        
        this.requiredTooltipDisplayData.password = 'tooltiptext tooltipHide';
        this.requiredTooltipDisplayData.confirmPassword = 'tooltiptext tooltipHide';

        this.errorTooltipDisplayData.email = 'tooltiptext tooltipHide';
        this.errorTooltipDisplayData.password = 'tooltiptext tooltipHide';
    }

    onEmailInvalid(event){

        if (!event.target.validity.valid) {
            event.target.setCustomValidity('Enter a valid email address')
        }
        
    }

    onEmailInput(event){

        event.target.setCustomValidity('')
    }

    onEmailClick(event){

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.remove('tooltipEmail');
    }

    onEmailBlur(event){

        let parent = event.target.parentElement.parentElement.parentElement;
        console.log('parent-', parent);
        parent.classList.add('tooltipEmail');
    }

    handleRegister(event){

        this.errorCheck = false;
        this.errorMessage = null;
        console.log('I am here');

        
        if(this.firstName && this.lastName && this.email && this.userName && this.password && this.confirmPassword){

            
            console.log('I am here');

            if(this.password != this.confirmPassword){

               
                this.passwordError = 'Password did not match. Please Make sure both the passwords match.';
                

                alert(this.passwordError);

                event.preventDefault();

              
                
                return;
            }

            let emailCheck = /^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(this.email);

            console.log('emailCheck--',emailCheck);

            if( emailCheck == null || emailCheck == undefined || emailCheck == false ){

                this.showTermsAndConditionsLoading = false;
                console.log('inside email check');
                
                this.emailError = 'Please enter a valid email address';
                alert(this.emailError);
               
                
                return;
            }

            let passwordCheck = /^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*#?&])[A-Za-z\d@$!%*#?&]{8,}$/.test(this.password);

            if(passwordCheck == null || passwordCheck == undefined || passwordCheck == false){

                this.showTermsAndConditionsLoading = false;

                
                this.passwordError = 'Password must be Minimum eight characters, at least one letter, one number and one special character.';
                
                alert(this.passwordError);
              
                
                return;
            }
            
            event.preventDefault();
            console.log(this.userName, 'username_____');
            isEmailExist({ username: this.userName })
            .then((result) => {

                console.log('login result---'+result, typeof result);
                
                if(result != null && result != undefined && result == true){

                    this.emailError = 'Your username already exists somewhere on the  Salesforce Ecosystem.';

                   
                    alert(this.emailError);
                  
                } else {

                    registerUser({ firstName: this.firstName, lastName: this.lastName, username: this.userName, email: this.email, communityNickname: this.firstName, password: this.password,
                    })
                        .then((result) => {
                                        
                            if(result){            
                                          
                                window.location.href = result;
            
                            } 
							
                            this.showTermsAndConditionsLoading = false;
                        })
                        .catch((error) => {
                            this.error = error;
            
                            console.log('error-',error);
            
                            this.showTermsAndConditionsLoading = false;
            
                            if(error && error.body && error.body.message){
            
                                this.showTermsAndConditions = false;
                                this.errorCheck = true;
                                this.errorMessage = error.body.message;
                               
                            }           
                            
                        });
                }

                
            })
            .catch((error) => {
                this.error = error;
             
                if(error && error.body && error.body.message){
                    
                    console.log('error msg-', error.body.message);
                }

                this.showTermsAndConditionsLoading = false;
				
            });
        
        }

        
    }

    handleTermsAndConditions(event){

        this.showTermsAndConditions = true;
    }

    handleFirstNameChange(event){

        this.firstName = event.target.value;
    }

    handleLastNameChange(event){

        this.lastName = event.target.value;
    }

    handleEmailChange(event){

        if(event.target.value){

            this.email = event.target.value;
            this.userName = this.email;
        
        } else {

            this.email = event.target.value;
            this.userName = this.email;
        }
    }  

    handlePasswordChange(event){

        this.password = event.target.value;
    }

    handleConfirmPasswordChange(event){

        this.confirmPassword = event.target.value;
    }

    closeTermsAndConditions(event){

        this.showTermsAndConditions = false;
    }


    handleEmailHover(event){
    }

}