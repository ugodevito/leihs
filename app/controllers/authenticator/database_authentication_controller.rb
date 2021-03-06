require 'digest/sha1'

class Authenticator::DatabaseAuthenticationController < Authenticator::AuthenticatorController

  $general_layout_path = 'layouts/backend/' + $theme + '/general'
     
  layout $general_layout_path
        
  def login_form_path
    "/authenticator/db/login"
  end
  
  def login
    if request.post?
      l = DatabaseAuthentication.authenticate(params[:login][:user], params[:login][:password])
      if l
        self.current_user = l.user
        if current_user.access_rights.size == 0
          render :text => _("You don't have any rights to access this application.") 
          return
        end
        redirect_back_or_default("/")
      else
        flash[:notice] = _("Invalid username/password")
        redirect_to :action => 'login'
      end
    end
  end

  def change_password
    if request.post?
      d = DatabaseAuthentication.find_or_create_by_login(params[:dbauth])
      d.update_attributes(params[:dbauth])
      d.password_confirmation = d.password
      unless d.save
        flash[:error] = d.errors.full_messages
      else
        flash[:notice] = _("Password changed")
      end
      render :update do |page|
        page.replace_html 'flash', flash_content
        flash.discard
      end
    end
    
  end
  
end
  
