import { Controller, Get } from '@nestjs/common';
//import { VaultService } from './vault.service';

@Controller()
export class AppController {
  @Get('/')
  getWelcomeMessage(): string {
    const username = process.env.db_username;
    const password = process.env.db_password;
    return `Welcome to NestJS application! Your username is ${username} and password is ${password}.`;
  }
  /*
  @Get()
  async getSecrets(): Promise<string> {
    const secrets = await this.vaultService.fetchSecrets();
    const formattedSecrets = secrets.map((secret) => {
      return `${secret.key}: ${JSON.stringify(secret.value)}`;
    });
    return `Welcome to NestJS application!\n\n${formattedSecrets.join('\n')}`;
  }
  */
}
