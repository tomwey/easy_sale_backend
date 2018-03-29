Rails.application.routes.draw do
  # 富文本上传路由
  mount RedactorRails::Engine => '/redactor_rails'
  
  ########### 微信公众号入口 ###########
  namespace :wechat, path: 'wx' do
    get  '/portal'      => 'portal#echo'
    post '/portal'      => 'portal#message', defaults: { format: 'xml' }
    get  '/yj-portal'   => 'portal#yujian'
    post '/pay_notify'  => 'portal#pay_notify'
    get  '/auth/redirect' => 'portal#auth', as: :auth_redirect
    get  '/auth/redirect2' => 'portal#app_auth_redirect', as: :auth_app_redirect
    get  '/auth/redirect_uri' => 'portal#redirect_uri', as: :auth_redirect_uri
    # get  '/share'       => 'share#offical'
    # get  '/events/:event_id/share' => 'share#event'
    get  '/share/event'   => 'share#event', as: :share_event
    get  '/share/hb'      => 'share#redbag', as: :share_redbag
    get  '/share/partin'  => 'share#partin', as: :share_partin
    get  '/share/invite'  => 'share#invite', as: :share_invite
    get  '/share/hb2'     => 'share#redbag2', as: :just_share_redbag # 仅仅是简单的分享
    get  '/share/result'  => 'share#result', as: :share_result
    get  '/share/partin_result'  => 'share#partin_result', as: :share_partin_result
    get  '/share/offical' => 'share#offical', as: :share_offical
    
    get '/qq_auth' => 'portal#qq_auth', as: :qq_auth
    
    get '/entry-help' => 'portal#entry_help', as: :entry_help
    
    # 用户优惠卡验证二维码
    # /user_card_qrcode?code=xxxxxx&i=123321&ak=3839282
    get  '/user_card_qrcode' => 'qrcode#user_card', as: :card_verify
    
    # 用户余额支付二维码
    # /user_pay_qrcode?code=xxxxxx&i=123321&ak=3839282
    get  '/user_pay_qrcode'  => 'qrcode#user_pay', as: :user_pay_verify
    
    # 获取水印二维码图片
    # /share_poster_qrcode?code=xxxx&i=123321&ak=38333
    get '/share_poster_qrcode' => 'qrcode#share_poster'
    
    get '/stats' => 'stats#index'
    
    # 抽奖路由
    resources :lucky_draws, path: :cj, only: [:show] do
      member do
        post :begin
        get  :results
      end
    end
    
    # 网页认证登录
    get    'login'    => 'sessions#new',       as: :login
    get    'redirect' => 'sessions#save_user', as: :redirect_uri
    delete 'logout'   => 'sessions#destroy',   as: :logout
    
    # 我的钱包
    get 'wallet' => 'share#wallet', as: :wallet
    
  end
  
  get '/qq/auth' => 'wechat/portal#qq_auth', as: :qq_auth
  
  namespace :app do 
    get '/download' => 'home#download', as: :download
    get '/install'  => 'home#install',  as: :install
    # get '/hack_download' => 'home#hack_download', as: :hack_download
    # get '/download/:filename.:format' => 'home#download2'
  end
  
  ########## 微信支付审核官方网页 ############
  namespace :approve, path: '' do
    root 'home#index'
    get '/new-event' => 'home#new_event'
    get '/charge'    => 'home#charge'
    get '/about'    => 'home#about'
    get '/events/:event_id/body' => 'home#event_body', as: :event_body
  end
  
  ######## 积分墙服务器回调 ################
  namespace :offerwall do
    get '/callback'          => 'home#callback'
    # get '/:channel_id/tasks' => 'home#tasks'
  end
  
  # 网页文档
  resources :pages, path: :p, only: [:show]
  
  resources :events, only: [:new, :create]
  
  # 后台系统登录
  devise_for :admins, ActiveAdmin::Devise.config
  
  # 后台系统路由
  ActiveAdmin.routes(self)
  
  # 商家会员系统登录
  # devise_for :merchants, path: "account", controllers: {
  #   registrations: :account,
  #   sessions: :sessions,
  # }
  # 
  # # 商家后台系统
  # namespace :portal, path: '' do
  #   root 'home#index'
  # end
  
  # 队列后台管理
  require 'sidekiq/web'
  authenticate :admin do
    mount Sidekiq::Web => 'sidekiq'
  end
  
  # API 文档
  mount GrapeSwaggerRails::Engine => '/apidoc'
  # 
  # API 路由
  mount API::Dispatch => '/api'
  
  match '*path', to: 'home#error_404', via: :all
end