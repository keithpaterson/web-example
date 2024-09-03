import {Button, FormControl, FormLabel, Input} from '@mui/joy';
import { library } from '@fortawesome/fontawesome-svg-core';
import { fas } from '@fortawesome/free-solid-svg-icons';
import {useState} from "react";

export interface Bodkin {
    id: number;
    name: string;
}

export function Bodkins() {
    library.add(fas);

    const [bodkins, setBodkins] = useState<Bodkin[]>([]);
    const [name, setName] = useState("");

    // Table helpers -->
    function getHeadings(data:object[]) {
        return Object.keys(data[0]).map(key => {
          return <th>{key}</th>;
        });
      }
      
    // `map` over the data to return
    // row data, passing in each mapped object
    // to `getCells`
    function getRows(data:object[]) {
        return data.map(obj => {
            return <tr>{getCells(obj)}</tr>;
        });
    }
    
    // Return an array of cell data using the
    // values of each object
    function getCells(obj:object) {
        return Object.values(obj).map(value => {
            return <td>{value}</td>;
        });
    }
    // <-- end table helpers

    function handleNameChanged(event: React.FormEvent<HTMLInputElement>) {
        console.log(event)
        const val:string = event.currentTarget.value;
        setName(val)
    }

    function handleNameKeyDown(event: React.KeyboardEvent<HTMLInputElement>) {
        if (event.key === 'Enter') {
            createBodkin({id: 0, name: name});
            setName('');
            listBodkins()
        }
    }

    function handleListClicked(event: React.MouseEvent<HTMLAnchorElement, MouseEvent>) {
        event.preventDefault()

        listBodkins()
            .catch(error => console.log(error))
    }

    function handleCreateClicked(event: React.MouseEvent<HTMLAnchorElement, MouseEvent>) {
        event.preventDefault()

        createBodkin({id:0, name: name})
            .catch(error => console.log(error));
        setName('')
        listBodkins()
    }

    function createBodkin(bodkin: Bodkin): Promise<string> {
        return fetch('http://localhost:32754/bodkins', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json;charset=UTF-8',
            },
            body: JSON.stringify(bodkin),
        })
            .then((response) => response.json)
            .then((data) => {
                return Promise.resolve(data.toString())
            })
            .catch((errors) => {
                const error: Error = new Error(errors?.map((e: Error)  => e.message).join('\n') ?? 'unknown')
                return Promise.reject(error);
            })
    }
      
    function listBodkins(): Promise<Bodkin[]> {
        return fetch('http://localhost:32754/bodkins', {
            method: 'GET',
            headers: {
                'Content-Type': 'application/json;charset=UTF-8',
            },
        })
            .then((response) => response.json())
            .then((data) => {
                console.log(data)
                setBodkins(data);
                return Promise.resolve(data)
            })
            .catch((errors) => {
                const error: Error = new Error(errors?.map((e: Error)  => e.message).join('\n') ?? 'unknown')
                return Promise.reject(error);
            })
    }

    return (
        <>
            <div>
                <Button sx={{mt: 1}} onClick={handleListClicked}>List</Button>
                <p>{bodkins.length} Bodkins:</p>
                {bodkins.length > 0 && (<>
                    <table>
                        <thead><tr>{getHeadings(bodkins)}</tr></thead>
                        <tbody>{getRows(bodkins)}</tbody>
                    </table> 
                </>)}
            </div>
            <div>
                <FormControl>
                    <FormLabel>Name:</FormLabel>
                    <Input
                        name="name"
                        type="string"
                        placeholder="name"
                        value={name}
                        onChange={handleNameChanged}
                        onKeyDown={handleNameKeyDown}
                    />
                </FormControl>
                <Button sx={{mt: 1}} onClick={handleCreateClicked}>Create</Button>
            </div>
        </>
    )
}

export default Bodkins