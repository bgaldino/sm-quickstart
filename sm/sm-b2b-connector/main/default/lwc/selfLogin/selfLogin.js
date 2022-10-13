import { LightningElement, track,api ,wire} from 'lwc';
import doLogin from '@salesforce/apex/CommunityAuthController.doLogin';
import { listContent } from 'lightning/cmsDeliveryApi';
import community_Id from '@salesforce/community/Id';
import { loadStyle } from 'lightning/platformResourceLoader';
import Colors from '@salesforce/resourceUrl/B2B_Colors';
import Fonts from '@salesforce/resourceUrl/B2B_Fonts';
import BoldFonts from '@salesforce/resourceUrl/B2B_Fonts_Bold';
import selfRegister from '@salesforce/label/c.Self_Register_URL';
import forgotPassword from '@salesforce/label/c.Forgot_Password_Url';
import basePathName from '@salesforce/community/basePath';




export default class LoginComponent extends LightningElement {


    username;
    password;
    @track errorCheck;
    @track errorMessage;
    _selfRegisterUrl = selfRegister;
    forgotpasswordurl = forgotPassword;
    communityName = basePathName;
    invalidLoginCred = false;
    invalidLogin = 'Incorrect Credentials';
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

        loadStyle( this, Fonts);
        loadStyle(this, BoldFonts);
        loadStyle(this, Colors);
        var meta = document.createElement("meta");
        meta.setAttribute("name", "viewport");
        meta.setAttribute("content", "width=device-width, initial-scale=1.0");
        document.getElementsByTagName('head')[0].appendChild(meta);
        console.log(this.communityName, 'communityName_____');
       
    }

    handleUserNameChange(event){

        this.username = event.target.value;
    }

    handlePasswordChange(event){
        
        this.password = event.target.value;
    }

    handleLogin(event){
        console.log(this.username, this.password);
        this.invalidLoginCred = false;   
       if(this.username && this.password){

        event.preventDefault();

        doLogin({ username: this.username, password: this.password })
            .then((result) => {
                
                console.log(result, '---result---');
             
                if(result == null){
                    
                    this.invalidLoginCred = true;   
                
                }else{

                    window.location.href = result;

                }
            })
            .catch((error) => {
                this.invalidLoginCred = true;   
                this.error = error;      
                this.errorCheck = true;
                this.errorMessage = error.body.message;
            });

        }

    }

}