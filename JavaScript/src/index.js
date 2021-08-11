const fetch = require("node-fetch")

const USERNAME = "mail@example.com"
const PASSWORD = "password"
const BASEURL = "https://your-gmsp-instance"

async function getRealmAndClientId(baseurl) {
    const url = new URL("/mssp-admin/public/config/realm", baseurl)
    const httpResponse = await fetch(url.toString(),
        {
            headers: {
                "Content-Type": "application/json"
            }
        }
    )
    const json = await httpResponse.json()
    return {clientId: json.clientId, realmId: json.realm}
}

async function getToken(baseUrl, username, password) {
    const {clientId, realmId} = await getRealmAndClientId(baseUrl)

    const formData = new URLSearchParams()
    formData.append("grant_type", "password")
    formData.append("username", username)
    formData.append("password", password)
    formData.append("client_id", clientId)

    const url = new URL(`/auth/realms/${realmId}/protocol/openid-connect/token`, baseUrl)
    const response = await fetch(url.toString(),
        {
            method: "POST",
            body: formData,
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
            }
        })

    if (response.status !== 200) {
        throw new Error(`Error: HttpStatus: ${response.status} \n`)
    }

    const json = await response.json()

    return (`${json.token_type} ${json.access_token}`)

}

async function getTargets() {
    const token = await getToken(BASEURL, USERNAME, PASSWORD)
    const url = new URL(`/targets`, BASEURL)

    const httpResponse = await fetch(url.toString(),
        {
            headers: {
                "Content-Type": "application/json",
                "Authorization": token
            }
        })

    try {
        return await httpResponse.json()
    }catch (e) {
        console.error(e)
    }

}

async function main() {
    const targetList = await getTargets()
    //targetList now contains the targets = Array<{id: number, name: string, ...}>
    console.log(targetList)
}

main()
    .then()
    .catch(e => console.error(e))
