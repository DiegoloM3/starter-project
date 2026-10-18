// Assigns a role to a registered user.
//
// Usage:
//   GOOGLE_APPLICATION_CREDENTIALS=/path/to/service-account.json \
//     npm run set-role -- <email> <journalist|reader>
//
// The role is written in two places:
// - The custom claim, which the security rules trust to grant permissions.
// - The public profile, so the app can show the role to other users.
//
// The user must sign out and sign in again (or refresh their ID token)
// for the new permissions to take effect.

import { initializeApp } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';
import { getFirestore } from 'firebase-admin/firestore';

const ROLES = ['journalist', 'reader'];

async function main() {
  const [email, role] = process.argv.slice(2);
  validateArguments(email, role);

  initializeApp();
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, buildClaimsFor(role));
  await getFirestore().doc(`users/${user.uid}`).update({ role });

  console.log(`${email} is now a ${role}. They must sign in again to apply the change.`);
}

function validateArguments(email, role) {
  if (!email || !ROLES.includes(role)) {
    throw new Error(`Usage: npm run set-role -- <email> <${ROLES.join('|')}>`);
  }
}

// Readers are the default role, so they carry no custom claim.
function buildClaimsFor(role) {
  return role === 'reader' ? null : { role };
}

main().catch((error) => {
  console.error(error.message);
  process.exit(1);
});
