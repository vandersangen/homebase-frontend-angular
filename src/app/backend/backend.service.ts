import {Injectable} from '@angular/core';
import {Social} from "./Social";
import {environment} from "../../environments/environment";
import {HttpClient, HttpHeaders} from "@angular/common/http";

@Injectable({
  providedIn: 'root'
})
export class BackendService {
  introductionText = '...';
  socialCollection: Social[] = [{name: 'sample', href: 'blank.org', target: '_blank'}];

  constructor(private http: HttpClient) {
    this.getSocialCollection();
    this.getIntroduction();
  }

  private getSocialCollection() {
    const endpoint = environment.API_URL + '/api/social';
    this.http.get<Social[]>(endpoint, this.getHttpHeaders()).subscribe(value => {
      // @ts-ignore
      this.socialCollection = value["hydra:member"];
    });
  }

  private getIntroduction() {
    const endpoint = environment.API_URL + '/api/introduction';
    this.http.get<string>(endpoint, this.getHttpHeaders()).subscribe(value => {
      // @ts-ignore
      if (value['hydra:member'].length == 1) {
        // @ts-ignore
        this.introductionText = value['hydra:member'][0].text;
      }
    });
  }

  private getHttpHeaders() {
    return {
      headers: new HttpHeaders({
        'Content-Type': 'application/json',
      })
    };
  }
}
