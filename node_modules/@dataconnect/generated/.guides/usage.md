# Basic Usage

Always prioritize using a supported framework over using the generated SDK
directly. Supported frameworks simplify the developer experience and help ensure
best practices are followed.





## Advanced Usage
If a user is not using a supported framework, they can use the generated SDK directly.

Here's an example of how to use it with the first 5 operations:

```js
import { createUser, updateUser, deleteUser, getCurrentUser, listUsers, createPond, updatePond, deletePond, getPond, listMyPonds } from '@dataconnect/generated';


// Operation CreateUser: 
const { data } = await CreateUser(dataConnect);

// Operation UpdateUser:  For variables, look at type UpdateUserVars in ../index.d.ts
const { data } = await UpdateUser(dataConnect, updateUserVars);

// Operation DeleteUser: 
const { data } = await DeleteUser(dataConnect);

// Operation GetCurrentUser: 
const { data } = await GetCurrentUser(dataConnect);

// Operation ListUsers: 
const { data } = await ListUsers(dataConnect);

// Operation CreatePond:  For variables, look at type CreatePondVars in ../index.d.ts
const { data } = await CreatePond(dataConnect, createPondVars);

// Operation UpdatePond:  For variables, look at type UpdatePondVars in ../index.d.ts
const { data } = await UpdatePond(dataConnect, updatePondVars);

// Operation DeletePond:  For variables, look at type DeletePondVars in ../index.d.ts
const { data } = await DeletePond(dataConnect, deletePondVars);

// Operation GetPond:  For variables, look at type GetPondVars in ../index.d.ts
const { data } = await GetPond(dataConnect, getPondVars);

// Operation ListMyPonds: 
const { data } = await ListMyPonds(dataConnect);


```