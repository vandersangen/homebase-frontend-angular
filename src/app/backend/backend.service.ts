import { Injectable } from '@angular/core';
import {Social} from "./Social";
import {environment} from "../../environments/environment";
import {HttpClient} from "@angular/common/http";
import {Observable} from "rxjs";


@Injectable({
  providedIn: 'root'
})
export class BackendService {
  constructor(private http: HttpClient) { }

  getSocialCollection(): Observable<Social[]> {
    let endpoint = environment.API_URL + '/api/socials';
    return this.http.get<Social[]>(endpoint);
  }
}
