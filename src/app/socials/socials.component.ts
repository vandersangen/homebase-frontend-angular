import {Component, Input, OnInit} from '@angular/core';
import {HttpClient} from "@angular/common/http";
import {Social} from "../backend/Social";
import {BackendService} from "../backend/backend.service";
import {Observable} from "rxjs";

@Component({
  selector: 'app-socials',
  templateUrl: './socials.component.html',
  styleUrls: ['./socials.component.css'],
})
export class SocialsComponent {
  title = 'Socials'

  constructor(private backendService: BackendService) {}

  get socialCollection() {
    return this.backendService.socialCollection;
  }
}
