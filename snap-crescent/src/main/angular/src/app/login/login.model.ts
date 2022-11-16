import { BaseResponse } from "../core/models/base-response";
import { SessionInfo } from "../core/models/session-info.model";

export class UserLoginRequest {
    username: string = '';
    password: string = '';
}

export class ResetPasswordRequest {
    username?: string = '';
}

export class UserLoginResponse extends BaseResponse{
    token!:string;
    user:SessionInfo
}