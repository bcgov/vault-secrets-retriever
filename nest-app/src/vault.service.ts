import { Injectable } from '@nestjs/common';
import * as Vault from 'node-vault';

@Injectable()
export class VaultService {
  private client: any;
  secret_path = 'apps/test/spar/app-spar';
  constructor() {
    this.client = Vault({ token: process.env.VAULT_TOKEN });
  }

  async fetchSecrets(): Promise<any> {
    try {
      const response = await this.client.list(this.secret_path);
      const secrets = await Promise.all(
        response.data.keys.map(async (key) => {
          const secret = await this.client.read(this.secret_path + `/${key}`);
          return { key, value: secret.data };
        }),
      );
      return secrets;
    } catch (error) {
      console.error('Error occurred while fetching secrets:', error);
      throw error;
    }
  }
}
