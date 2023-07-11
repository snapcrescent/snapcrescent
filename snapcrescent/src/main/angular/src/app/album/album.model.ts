import { Thumbnail } from "../asset/asset.model";
import { BaseUiBean } from "../core/models/base.model";
import { User } from "../user/user.model";

export class Album extends BaseUiBean{
  
  name:string = '';
  publicAccess?:boolean = false;

  albumTypeName?:string = '';
  albumType?:number = 0;

  ownedByMe?:boolean = false;
  sharedWithOthers?:boolean = false;

  albumThumbnail?:Thumbnail;

  users? : User[] = [];
  newPassword? : string = '';

  publicAccessUserObject?: User;
}

export class CreateAlbumAssetAssnRequest {
  albums:Album[];
  assetIds:number[];
}

export let AlbumType = {
  DEFAULT: {
    id: 1,
    label: "Default"
  },
  CUSTOM: {
    id: 2,
    label: "Custom"
  }
};