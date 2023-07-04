import { Thumbnail } from "../asset/asset.model";
import { BaseUiBean } from "../core/models/base.model";

export class Album extends BaseUiBean{
  
  name:string;
  publicAccess:boolean;

  albumTypeName:string;
  albumType:number

  ownedByMe:boolean;
  sharedWithOthers:boolean;

  albumThumbnail:Thumbnail;
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