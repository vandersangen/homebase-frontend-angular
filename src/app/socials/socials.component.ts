import {Component} from '@angular/core';
import {BackendService} from "../backend/backend.service";

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
