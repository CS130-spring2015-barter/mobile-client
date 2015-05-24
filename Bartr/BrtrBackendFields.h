//
//  BrtrBackendFields.h
//  Bartr
//
//  Created by admin on 5/23/15.
//  Copyright (c) 2015 Bartr. All rights reserved.
//
#ifndef Bartr_BrtrBackendFields_h
#define Bartr_BrtrBackendFields_h

#define ENDPOINT  @"http://barter.elasticbeanstalk.com/"

#define ROUTE_ITEM_GET @"item/geo"
#define ROUTE_ITEM_ADD @"item"
#define ROUTE_ITEM_DELETE @"item/%d"
#define ROUTE_ITEM_UPDATE @"item/%d"
#define ROUTE_ITEM_LIKED @"item/liked"
#define ROUTE_ITEM_SEEN @"item/seen"

#define ROUTE_USER_CREATE @"user"
#define ROUTE_USER_DELETE @"user/%@"
#define ROUTE_USER_GET    @"user/%@"
#define ROUTE_USER_UPDATE @"user/%@"
#define ROUTE_USER_LOGIN  @"user/login"

#define KEY_USER_EMAIL      @"email"
#define KEY_USER_PASSWORD   @"password"
#define KEY_USER_ID         @"user_id"
#define KEY_USER_TOKEN      @"token"
#define KEY_USER_FIRST_NAME @"first_name"
#define KEY_USER_LAST_NAME  @"last_name"
#define KEY_USER_LOC_LAT    @"latitude"
#define KEY_USER_LOC_LONG   @"longitude"
#define KEY_USER_ABOUTME    @"about_me"
#define KEY_USER_IMAGE      @"user_mage"
#define KEY_USER_INFO       @"user_info"

#define KEY_ITEM_ID     @"item_id"
#define KEY_ITEM_TITLE  @"item_title"
#define KEY_ITEM_DESC   @"item_description"
#define KEY_ITEM_IMAGE  @"item_image"
#define KEY_ITEM_INFO   @"item_info"
#endif
