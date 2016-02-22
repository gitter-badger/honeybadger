# This is the main router file
# You can also create your own controllers in app/controllers/

module Honeybadger

  class AdminApp < Padrino::Application

    register Sinatra::MultiRoute
    register Padrino::Mailer
    register Padrino::Helpers
    register WillPaginate::Sinatra

    enable :sessions
    enable :reload
    layout :admin

    ### this runs before all routes ###
    before do

      only_for("admin")
      @title = config('site_title') || "Honeybadger CMS"

    end
    ###

    ### routes ###
    get '/' do
      render "index"
    end

    # user routes
    get '/users' do
      @users = User.order(:id).reverse
      render "users"
    end

    get '/user/(:id)' do
      @user = User[params[:id]]
      render "user"
    end

    get '/test' do
      render "test"
    end

    post '/user/save/(:id)' do
      data = params[:user]

      # validate fields
      rules = {        
        :first_name => {:type => 'string', :required => true},        
        :email => {:type => 'email', :required => true},
        :password => {:type => 'string', :min => 6, :confirm_with => :password_confirmation},
      }
      validator = Honeybadger::Validator.new(data, rules)

      if !validator.valid?
        msg = validator.errors
        flash.now[:error] = msg[0][:error]
        if params[:id].blank?
          @user = User.create(data)
        else
          @user = User[params[:id]].set(data)
        end
      else

        # create or update
        if params[:id].blank? # create
          @user = User.register_with_email(data, data[:role])
          if @user
            flash.now[:success] = 'Record has been created!'
          else
            flash.now[:error] = 'Sorry, there was a problem creating'
          end
        else # update
          @user = User[params[:id]]
          if !@user.nil?
            @user = @user.set(data)

            if @user.save

              flash.now[:success] = 'Record has been updated!'

              # if updating current user, refresh session and reload page
              if session[:user][:id] == @user[:id]
                session[:user] = @user.values
              end

            else
              flash.now[:error] = 'Sorry, there was a problem updating'
            end
          end
        end # end save

      end # end validator

      render "user"

    end

    get '/user/delete/(:id)', :provides => :js do
      model = User[params[:id]]
      if !model.nil? && model.destroy
        msg = output_js_success('Record has been deleted!')
        msg += "$('#row_#{params[:id]}').slideUp();"
      else
        msg = output_js_success('Sorry, there was a problem deleting')
      end
    end
    # end user routes

    # post routes
    get '/posts' do
      @posts = Post.order(:id).reverse
      render "posts"
    end

    get '/post/(:id)' do
      @post = Post[params[:id]]
      render "post"
    end

    post '/post/save/(:id)', :provides => :js do
      data = params[:post]

      # validate fields
      rules = {
        :user_id => {:type => 'numeric', :required => true},
        :title => {:type => 'string', :min => 2, :max => 256, :required => true},
        :content => {:type => 'string', :required => true},
      }
      validator = Honeybadger::Validator.new(data, rules)
      if !validator.valid?
        msg = output_js_validator(validator.errors, 'post')
      else

        if params[:id].blank? # create
          model = Post.new(data).save
          if model
            msg = output_js_success('Record has been created!')
            msg += "location.href = '/admin/posts';"
          else
            msg = output_js_error('Sorry, there was a problem creating')
          end
        else # update
          model = Post[params[:id]]
          if !model.nil?
            model = model.set(data)
            if model.save
              msg = output_js_success('Record has been updated!')
            else
              msg = output_js_error('Sorry, there was a problem updating')
            end
          end
        end # end save

      end  # end validator

      msg

    end

    get '/post/delete/(:id)', :provides => :js do
      model = Post[params[:id]]
      if !model.nil? && model.destroy
        msg = output_js_success('Record deleted!')
        msg += "$('#row_#{params[:id]}').slideUp();"
      else
        msg = output_js_error('Sorry, there was a problem deleting')
      end
    end
    # end post routes


    # settings routes
    get '/settings' do
      @settings = Setting.order(:id).reverse.all
      @settings = Setting[1]
      render "settings"
    end

    post '/settings/save', :provides => :js do
      data = params
      abort

      msg
    end
    # end setting routes

    ### end of routes ###


    ### utility methods ###
    def output(val)
      case val
      when String
        if val.is_json?(val)
          content_type :json
          val.to_json
        else
          val
        end
      when Hash
        content_type :json
        val.to_json
      when Array
        content_type :json
        val.to_json
      when Fixnum
        val
      else
        val
      end
    end



  end # end class

end # end module
